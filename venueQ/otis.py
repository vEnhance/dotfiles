import json
import os
import pprint
import random
import re
import smtplib
import ssl
import subprocess
import threading
import time
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from pathlib import Path
from typing import Any, Callable, List, Optional, Type

import markdown
import requests
from dotenv import load_dotenv

from venueQ import Data, VenueQNode, VenueQRoot, logger

load_dotenv(Path('~/dotfiles/secrets/otis.env').expanduser())
TOKEN = os.getenv('OTIS_WEB_TOKEN')
AK = os.getenv('AK')
OTIS_GMAIL_USERNAME = os.getenv('OTIS_GMAIL_USERNAME') or ''
assert TOKEN is not None
PRODUCTION = os.getenv('PRODUCTION', False)
if PRODUCTION:
    OTIS_API_URL = 'https://otis.evanchen.cc/aincrad/api/'
else:
    OTIS_API_URL = 'http://127.0.0.1:8000/aincrad/api/'

OTIS_TMP_DOWNLOADS_PATH = Path('/tmp/junk-for-otis')
if not OTIS_TMP_DOWNLOADS_PATH.exists():
    OTIS_TMP_DOWNLOADS_PATH.mkdir()
    OTIS_TMP_DOWNLOADS_PATH.chmod(0o777)
HANDOUTS_PATH = Path('~/ProGamer/OTIS/Materials').expanduser()
NOISEMAKER_SOUND_PATH = Path('~/dotfiles/sh-scripts/noisemaker.sh').expanduser()


def send_email(
    subject: str,
    recipients: None | List[str] = None,
    bcc: None | List[str] = None,
    body: None | str = None,
    callback: None | Callable[[], None] = None,
):
    mail = MIMEMultipart('alternative')
    mail['From'] = 'OTIS Overlord <evan@evanchen.cc>'
    assert recipients is not None or bcc is not None
    if recipients is not None:
        mail['To'] = ', '.join(recipients)
    if bcc is not None:
        mail['Bcc'] = ', '.join(bcc)
    mail['Subject'] = subject

    plain_msg = body or ''
    plain_msg += '\n' * 2
    plain_msg += '**Evan Chen (陳誼廷)**<br>' + '\n'
    plain_msg += '[https://web.evanchen.cc](https://web.evanchen.cc/)'
    html_msg = markdown.markdown(plain_msg,
                                 extensions=['extra', 'sane_lists', 'smarty'])
    mail.attach(MIMEText(plain_msg, 'plain'))
    mail.attach(MIMEText(html_msg, 'html'))

    password = subprocess.run(
        ['secret-tool', 'lookup', 'user', OTIS_GMAIL_USERNAME, 'type', 'gmail'],
        text=True,
        capture_output=True).stdout

    email_log_filename = f"email{datetime.now().strftime('%Y%m%d-%H%M%S')}.mkd"
    with open(OTIS_TMP_DOWNLOADS_PATH / email_log_filename, "w") as f:
        print(plain_msg, file=f)

    if PRODUCTION:
        target_addrs = (recipients or []) + (bcc or [])

        def do_send():
            session = smtplib.SMTP('smtp.gmail.com', 587)
            try:
                session.starttls(context=ssl.create_default_context())
                session.login(f'{OTIS_GMAIL_USERNAME}@gmail.com', password)
                session.sendmail('evan@evanchen.cc', target_addrs,
                                 mail.as_string())
            except Exception as e:
                logger.error(f"Email '{subject}' failed to send", exc_info=e)
                subprocess.run(
                    [NOISEMAKER_SOUND_PATH.absolute().as_posix(), '7'])
            else:
                logger.info(f"Email '{subject}' sent successfully!")
                subprocess.run(
                    [NOISEMAKER_SOUND_PATH.absolute().as_posix(), '4'])
                if callback is not None:
                    callback()

        logger.debug(f"Email '{subject}' to {target_addrs} queued.")
        t = threading.Thread(target=do_send)
        t.start()
    else:
        assert password
        print("Testing an email send from <evan@evanchen.cc>")
        print(mail.as_string())
        if callback is not None:
            callback()


def query_otis_server(payload: Data,
                      play_sound=True) -> Optional[requests.Response]:
    payload['token'] = TOKEN
    logger.debug(payload)
    try:
        resp = requests.post(OTIS_API_URL, json=payload)
    except requests.exceptions.ConnectionError:
        logger.warning("Could not connect to server")
        return None
    else:
        if resp.status_code == 200:
            logger.info("Got a 200 response back from server")
            if play_sound:
                subprocess.run(
                    [NOISEMAKER_SOUND_PATH.absolute().as_posix(), '5'])
            return resp
        else:
            logger.error(
                f"OTIS-WEB threw an exception with status code {resp.status_code}\n"
                + resp.content.decode('utf-8'))
            return None


class ProblemSet(VenueQNode):
    EXTENSIONS = ('pdf', 'txt', 'tex', 'jpg', 'png')
    HARDNESS_CHART = {
        'E': 2,
        'M': 3,
        'H': 5,
        'Z': 9,
        'X': 0,
        'I': 0,
    }
    VON_RE = re.compile(r'^\\von([EMHZXI])(R?)(\[.*?\]|\*)?\{(.*?)\}')
    PROB_RE = re.compile(r'^\\begin\{prob([EMHZXI])(R?)\}')
    GOAL_RE = re.compile(r'^\\goals\{([0-9]+)\}\{([0-9]+)\}')

    EXTRA_FIELDS = (
        'student__pk',
        'student__user__email',
        'student__user__first_name',
        'student__user__last_name',
        'next_unit_to_unlock__code',
        'next_unit_to_unlock__group__name',
        'unit__code',
        'unit__group__name',
        'unit__group__slug',
        'student__reg__aops_username',
        'student__reg__container__semester__end_year',
        'student__reg__country',
        'student__reg__gender',
        'student__reg__graduation_year',
        'num_accepted_all',
        'num_accepted_current',
    )

    ext: Optional[str] = None

    def get_initial_data(self) -> Data:
        return {
            'action': 'grade_problem_set',
        }

    def get_name(self, data: Data) -> str:
        return str(data['pk'])

    def get_path(self, ext: Optional[str] = None):
        if ext is None:
            assert self.ext is not None
            ext = self.ext
        assert ext in ProblemSet.EXTENSIONS, f"{ext} is not a valid extension"
        fname = f'otis_{self.data["pk"]:06d}'
        fname += '_'
        fname += self.data['name'].replace(' ', '_')
        fname += '_'
        fname += self.data['unit'].replace(' ', '_')
        return OTIS_TMP_DOWNLOADS_PATH / f"{fname}.{ext}"

    def init_hook(self):
        data = self.data

        # add/cleanup fields for grading
        if data['status'] == 'P':
            data['status'] = 'A'
        grade = 12 - (data['student__reg__graduation_year'] -
                      data['student__reg__container__semester__end_year'])
        data['info'] = f"{data['student__reg__country']} "
        data['info'] += f"({grade}{data['student__reg__gender']}) "
        data['info'] += f"aka {data['student__reg__aops_username']}"
        data['info'] += r" | "
        data['info'] += f"{data['num_accepted_current']}u this year; "
        data['info'] += f"{data['num_accepted_all']}u all-time"
        data[
            'name'] = f"{data['student__user__first_name']} {data['student__user__last_name']}"
        data['unit'] = f"{data['unit__code']} {data['unit__group__name']}"
        # stop getting trolled by the kids
        if data['unit__group__slug'] == 'dummy':
            data['clubs'] = min(data['clubs'], 1)
            data['hours'] = min(data['hours'], 2)

        data['feedback'] = data['feedback']\
                .replace(r"'", r"’").replace(r'"', r'＂')
        data['special_notes'] = data['special_notes']\
                .replace(r"'", r"’").replace(r'"', r'＂')

        # collect data about the handout
        if HANDOUTS_PATH.exists():
            filename = f'**/{data["unit__code"]}-{data["unit__group__slug"]}.tex'
            handouts = list(HANDOUTS_PATH.glob(filename))
            assert len(handouts) == 1
            total = 0
            min_clubs = 0
            high_clubs = 0
            num_problems = 0
            with open(handouts[0]) as f:
                for line in f:
                    if (m := ProblemSet.VON_RE.match(line)) is not None:
                        d, *_ = m.groups()
                    elif (m := ProblemSet.PROB_RE.match(line)) is not None:
                        d, *_ = m.groups()
                    elif (m := ProblemSet.GOAL_RE.match(line)) is not None:
                        a, b = m.groups()
                        min_clubs = int(a)
                        high_clubs = int(b)
                        continue
                    else:
                        continue
                    assert d is not None
                    w = ProblemSet.HARDNESS_CHART[d]
                    total += w
                    num_problems += 1
            data["clubs_max"] = (f"max {1+total} | "
                                 f"hi {high_clubs} | "
                                 f"min {min_clubs}")
        else:
            data["clubs_max"] = None
            total = None
            num_problems = None

        if (total is not None and num_problems is not None and total > 1 and
                num_problems > 2 and data['clubs'] >= total - 1 and
                not self.temp_path('mkd').exists()):
            with open(self.temp_path('mkd'), 'w') as f:
                print(AK, file=f)

        # save file
        for ext in ProblemSet.EXTENSIONS:
            if self.get_path(ext).exists():
                self.ext = ext
                break
        else:
            url = f"https://storage.googleapis.com/otisweb-media/{data['upload__content']}"
            _, ext = os.path.splitext(data['upload__content'])
            ext = ext.lstrip('.')
            ext = ext.lower()
            assert ext in ProblemSet.EXTENSIONS, f"{ext} is not a valid extension"
            self.ext = ext
            try:
                file_response = requests.get(url=url)
                self.get_path().write_bytes(file_response.content)
                self.get_path().chmod(0o666)
            except ConnectionError:
                logger.warning(f"Could not get {url}")

        # move extraneous data into an "xtra" dictionary
        data['xtra'] = {}
        for k in ProblemSet.EXTRA_FIELDS:
            data['xtra'][k] = data.pop(k)

    def on_buffer_open(self, data: Data):
        super().on_buffer_open(data)
        self.edit_temp(extension='mkd')
        if self.ext == 'pdf':
            tool = 'zathura'
        elif self.ext == 'tex' or self.ext == 'txt':
            tool = 'gvim'
        elif self.ext == 'png' or self.ext == 'jpg':
            tool = 'feh'
        else:
            raise AssertionError
        subprocess.Popen([tool, self.get_path().absolute()])

    def compose_email_body(self, data: Data, comments: str) -> str:
        salutation = random.choice(["Hi", "Hello", "Hey"])
        closing = random.choice([
            "Cheers",
            "Cheers",
            "Best",
            "Regards",
            "Warm wishes",
            "Later",
            "Cordially",
            "With appreciation",
            "Sincerely",
        ])

        student_name = f"{data['student__user__first_name']} {data['student__user__last_name']}"

        body = (f"{salutation} {data['student__user__first_name']},\n\n"
                f"{comments}\n\n"
                "If you have questions or comments, or need anything else, "
                "reply directly to this email.\n\n"
                f"{closing},\n\n"
                "Evan (aka OTIS Overlord)")
        link_to_portal = f"https://otis.evanchen.cc/dash/portal/{data['student__pk']}/"
        link_to_pset = f"https://otis.evanchen.cc/dash/pset/{data['pk']}/"

        body += '\n\n' + '-' * 40 + '\n\n'
        body += (r"- **Sent to**: "
                 f"[{student_name}]({link_to_portal}) "
                 f"《{data['student__user__email']}》\n"
                 f"- **Submission**: [ID {data['pk']}]({link_to_pset})\n")
        if data['status'] == 'A':
            body += (
                r"- **Unit completed**: "
                f"`{data['unit__code']}-{data['unit__group__slug']}`\n"
                r"- **Earned**: "
                f"{data.get('clubs', 0)} clubs and {data.get('hours', 0)} hearts\n"
            )
            body += r"- **Next unit**: "
            if 'next_unit_to_unlock__code' in data:
                body += f"{data['next_unit_to_unlock__code']} {data['next_unit_to_unlock__group__name']}"
            else:
                body += r"*None specified*"
        elif data['status'] == 'R':
            body += r"- Submission was rejected, see explanation above."
        if data['feedback']:
            body += "\n\n"
            body += r"**Mini-survey response**:" + "\n"
            if (s := os.getenv('MS_HEADER')) is not None:
                body += "\n" + s + "\n\n"
            body += f"```\n{data['feedback']}\n```"
        if data['special_notes']:
            body += "\n\n"
            body += r"**Special notes**:" + "\n"
            body += f"```\n{data['special_notes']}\n```"
        return body

    def on_buffer_close(self, data: Data):
        super().on_buffer_close(data)

        for k in ProblemSet.EXTRA_FIELDS:
            data[k] = data['xtra'][k]
        del data['xtra']
        logger.debug(data)

        comments_to_email = self.read_temp(extension='mkd').strip()
        if (data['status'] in ('A', 'R')) and comments_to_email != '':
            if query_otis_server(payload=data) is not None:
                body = self.compose_email_body(data, comments_to_email)
                recipient = data['student__user__email']
                verdict = "completed" if data[
                    'status'] == 'A' else "NOT ACCEPTED (action req'd)"
                subject = f"OTIS: {data['unit__code']} {data['unit__group__name']} was {verdict}"

                def callback():
                    if data['status'] == 'R':
                        self.get_path().unlink()
                    self.erase_temp(extension='mkd')
                    self.delete()

                send_email(
                    subject=subject,
                    recipients=[recipient],
                    body=body,
                    callback=callback,
                )
            else:
                logger.warning("Server query failed, so no action taken")
        else:
            logger.info("Did not attempt to process submission")


class ProblemSetCarrier(VenueQNode):

    def get_class_for_child(self, data: Data) -> Type[ProblemSet]:
        del data
        return ProblemSet


class Inquiries(VenueQNode):

    def init_hook(self):
        self.data['accept_all'] = False

    def on_buffer_close(self, data: Data):
        super().on_buffer_close(data)
        if data['accept_all']:
            if query_otis_server(payload={'action': 'accept_inquiries'}):
                body = "This is an automated message to notify you that your recent unit petition\n"
                body += f"was processed on {datetime.utcnow().strftime('%-d %B %Y, %H:%M')} UTC."
                body += "\n\n"
                body += f"Have a nice {datetime.utcnow().strftime('%A')}."
                bcc_addrs = list(
                    set(inquiry['student__user__email']
                        for inquiry in data['inquiries']))
                subject = "OTIS unit petition processed"
                send_email(subject=subject, bcc=bcc_addrs, body=body)


class Suggestion(VenueQNode):
    statement: str
    solution: str

    def get_name(self, data: Data) -> str:
        return str(data['pk'])

    def get_initial_data(self) -> Data:
        return {
            'action': 'mark_suggestion',
        }

    def init_hook(self):
        self.statement = self.data.pop('statement')
        self.solution = self.data.pop('solution')
        self.data['status'] = 'SUGG_OK'

    def on_buffer_open(self, data: Data):
        super().on_buffer_open(data)
        self.edit_temp(extension='mkd')
        tmp_path = f"/tmp/sg{int(time.time())}.tex"

        with open(tmp_path, 'w') as f:
            print(self.statement, file=f)
            print('\n---\n', file=f)
            if data['acknowledge'] is True:
                print(r'\emph{This problem and solution were contributed by ' +
                      data['user__first_name'] + ' ' + data['user__last_name'] +
                      '}.',
                      file=f)
                print('', file=f)
            print(self.solution, file=f)
        subprocess.Popen([
            "xfce4-terminal",
            "-x",
            "python",
            "-m",
            "von",
            "add",
            data['source'],
            "-f",
            tmp_path,
        ])

    def on_buffer_close(self, data: Data):
        super().on_buffer_close(data)
        comments_to_email = self.read_temp(extension='mkd').strip()
        if comments_to_email != '':
            recipient = data['user__email']
            subject = f"OTIS: Suggestion {data['source']}: "
            if data['status'] == 'SUGG_OK' or data['status'] == 'SUGG_NOK':
                subject += 'Accepted'
            if data['status'] == 'SUGG_REJ':
                subject += 'Rejected'
            if data['status'] == 'SUGG_EDT':
                subject += 'REVISIONS REQUESTED'
            body = comments_to_email
            body += '\n\n' + '-' * 40 + '\n\n'
            body += r"```latex" + "\n"
            body += self.statement
            body += "\n" + r"```"

            def callback():
                if query_otis_server(payload=data) is not None:
                    self.delete()
                    self.erase_temp(extension='mkd')

            send_email(
                subject=subject,
                recipients=[recipient],
                body=body,
                callback=callback,
            )


class SuggestionCarrier(VenueQNode):

    def get_class_for_child(self, data: Data):
        return Suggestion


class Job(VenueQNode):

    def get_name(self, data: Data) -> str:
        return str(data['pk'])

    def get_initial_data(self) -> Data:
        return {
            'action': 'triage_job',
        }

    def init_hook(self):
        pass

    def on_buffer_open(self, data: Data):
        super().on_buffer_open(data)
        self.edit_temp(extension='mkd')

    def on_buffer_close(self, data: Data):
        super().on_buffer_close(data)
        comments_to_email = self.read_temp(extension='mkd').strip()
        if comments_to_email != '' and self.data['progress'] != 'JOB_SUB':
            verdict = 'Accepted' if self.data['progress'] == 'JOB_VFD' \
                    else 'CHANGES REQUESTED'
            recipient = data['assignee__user__email']
            subject = f"OTIS: Task {data['name']} from {data['folder__name']} triaged: {verdict}"
            body = comments_to_email
            body += '\n\n' + '-' * 40 + '\n\n'
            body += '**Deliverable**: ' + data['worker_deliverable']
            body += '\n\n'
            body += '**Notes**: ' + data['worker_notes']

            def callback():
                if query_otis_server(payload=data) is not None:
                    self.delete()
                    self.erase_temp(extension='mkd')

            send_email(
                subject=subject,
                recipients=[recipient],
                body=body,
                callback=callback,
            )


class JobCarrier(VenueQNode):

    def get_class_for_child(self, data: Data):
        return Job


class OTISRoot(VenueQRoot):

    def get_class_for_child(self, data: Data):
        if data['_name'] == 'Problem sets':
            return ProblemSetCarrier
        elif data['_name'] == 'Inquiries':
            return Inquiries
        elif data['_name'] == 'Suggestions':
            return SuggestionCarrier
        elif data['_name'] == 'Jobs':
            return JobCarrier
        else:
            raise ValueError(f"wtf is {data['_name']}")


QUEUE_FOLDER = Path('~/ProGamer/OTIS/queue').expanduser()
JSON_SAVED = QUEUE_FOLDER / 'init.json'

if __name__ == "__main__":
    otis_response = query_otis_server(
        payload={
            'token': TOKEN,
            'action': 'init'
        },
        play_sound=False,
    )
    if otis_response is not None:
        otis_json: dict[str, Any] = otis_response.json()
        logger.debug(f"Server returned {otis_response.status_code}")
        logger.debug(f"Headers:\n{pprint.pformat(dict(otis_response.headers))}")
        logger.debug(f"NAME: {otis_json['_name']}")
        logger.debug(f"TIME: {otis_json['timestamp']}")
        logger.debug(
            f"ITEMS: {pprint.pformat(otis_json['_children'], indent=0, width=100)}"
        )
        with open(JSON_SAVED, 'w') as f:
            json.dump(otis_json, f, indent=2)
    elif JSON_SAVED.exists():
        with open(JSON_SAVED) as f:
            otis_json = json.load(f)
        logger.info("Using saved JSON file...")
        assert otis_json is not None
    else:
        raise ValueError('o no')

    if PRODUCTION:
        otis_dir = QUEUE_FOLDER
    else:
        otis_dir = Path('/tmp/otis-debug')
    if not otis_dir.exists():
        otis_dir.mkdir()
    ROOT_NODE = OTISRoot(
        data=otis_json,
        root_dir=otis_dir,
        shelf_life=12,
    )
