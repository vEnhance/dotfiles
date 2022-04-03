// ==UserScript==
// @name         MoreGrader
// @namespace    https://web.evanchen.cc/
// @version      1.4
// @description  More grader info
// @author       oneplusone and vEnhance
// @match        https://artofproblemsolving.com/contests/us*-20*/grade*
// @match        https://artofproblemsolving.com/contests/usomo/g*
// @match        https://artofproblemsolving.com/contests/usojmo/g*
// @match        https://artofproblemsolving.com/contests/usemo/g*
// @match        https://kzaopstest.com/contests/*/grader
// @match        https://aopstest.com/contests/*/grader
// @match        https://aopstest2.com/contests/*/grader
// @match        https://kzaopstest.com/contests/*/grader?
// @match        https://aopstest.com/contests/*/grader?
// @match        https://aopstest2.com/contests/*/grader?
// @grant        none
// ==/UserScript==

AoPS.the_score_bucket = {};
AoPS.the_eval_bucket = {
    '1': {},
    '2': {},
    '3': {},
    '4': {},
    '5': {},
    '6': {},
};
AoPS.the_conflict_bucket = {
    '1': {},
    '2': {},
    '3': {},
    '4': {},
    '5': {},
    '6': {},
};

const main_template = Handlebars.compile(`
<td class="id-column {{status}}" {{#if conflict }}style="background-color: #dd8888"{{/if}}>
		<a class="submission-link" href="{{submission_path}}" target="_blank">{{sub_id}}</a>
        {{#if conflict}}
        [{{ combined_score }}]
        {{else}}
            {{#if any_scores}}
                {{#if i_am_done}}
                [<span class="own-score">{{ combined_score }}</span>]
                {{else}}
                [<span class="hidden-total-score toggle-total-score">{{ combined_score }}</span>]
                {{/if}}
            {{/if}}
        {{/if}}
		{{#if admin}}
			<br>
			{{#if ../locked}}
			<a class="btn btn-primary unfinalize-btn" data-sub-id="{{id}}"><i class="fas fa-lock-open"></i> UNFINALIZE</a>
			{{else}}
			<a class="btn btn-primary finalize-btn" data-sub-id="{{id}}"><i class="fas fa-lock"></i> FINALIZE</a>
			{{/if}}
		{{/if}}
	</td>
	{{#each evals}}
		<td class="eval-container {{../status}}"
               {{#if labels.conflict }}style="background-color: #cc7777"{{/if}}>
            <div>
			{{#if labels.locked}}
				<h5 class="locked {{state}}"><i class="fas fa-lock"></i> LOCKED</h5>

			{{else}}
				<div class="entry-label">
					{{#if labels.unavailable}}
						<h5 class="unavailable {{state}}"><i class="fas fa-ban"></i> UNAVAILABLE</h5>
					{{/if}}
					{{#if labels.claimed}}
						<h5 class="unavailable {{state}}"><i class="fas fa-exclamation-circle"></i> IN PROGRESS</h5>
					{{/if}}
					{{#if labels.done}}
						<h5 class="unavailable {{state}}"><i class="fas fa-check-circle"></i> DONE</h5>
					{{/if}}
					{{#if labels.conflict}}
						<h5 class="unavailable {{state}}"><i class="fas fa-ban"></i> CONFLICT</h5>
					{{/if}}
                    {{#if buttons.admin_override}}
                        <a class="btn btn-primary override-btn" data-eval-id="{{id}}"><i class="fas fa-user-cog"></i> ADMIN</a>
                    {{/if}}
				</div>
			{{/if}}
            </div>

			{{#if graded}}
                {{#if i_am_done}}
                [<span class="own-score">{{score}}</span>]
                {{else}}
                [<span class="hidden-indiv-score toggle-indiv-score">{{score}}</span>]
                {{/if}}
            {{/if}}
			{{#if graded}}
				<a class="usemo-hide-heading" onclick="$(this).next().toggle();$(this).toggleClass('usemo-hide-open');return false;">{{ grader_display_name }}</a>
				<div class="usemo-hide-content" style="display:none;">
					<b>Score: </b>{{score}}
					<br><b>Comments: </b> {{comments}}
				</div>
            {{ else }}
                {{#if buttons.grade}}
                {{else}}
                {{grader_display_name}}
                {{/if}}
			{{/if}}
			{{#if labels.locked}}
			{{else}}
                <div class="entry-buttons">
					{{#if buttons.grade}}
						<a class="btn btn-primary claim-btn" data-eval-id="{{id}}"><i class="fas fa-book-reader"></i> GRADE</a>
					{{/if}}
					{{#if buttons.edit}}
						<a class="btn btn-primary edit-btn" data-eval-id="{{id}}"><i class="fas fa-pencil-alt"></i> EDIT</a>
					{{/if}}
					{{#if buttons.conflict}}
						<a class="btn btn-danger edit-btn" data-eval-id="{{id}}"><i class="fas fa-exclamation"></i> RESOLVE CONFLICT</a>
					{{/if}}
					{{#if buttons.unclaim}}
						<a class="btn btn-primary unclaim-btn" data-eval-id="{{id}}"><i class="fas fa-undo"></i> UNCLAIM</a>
					{{/if}}
				</div>
            {{/if}}
		</td>
	{{/each}}
	<td class="eval-container {{status}}">
		{{#if topic}}
			<a class="aops-font open-topic" category_id={{topic/c}} topic_id="{{topic/t}}"
				title="View discussion about this entry"
				href="/community/c{{topic/c}}h{{topic/t}}" target="_blank">t</a>
		{{/if}}
	</td>`);

AoPS.Contests.Views.ContestGraderEntry = AoPS.Contests.Views.ContestGraderEntry.extend({
        // hijack the render function and use my own template for it
        render: function() {
            this.setTplVars(),
            this.$el.html(main_template(this.vars));
        },
        setTplVars: function() {
            var evals = this.model.get("evals");
            /* Get extra variables */
            var i_am_done = false;
            var scores = [];
            for (var i=0; i<evals.length; i++) {
                if ((Number(evals[i].grader_id) === Number(AoPS.session.user_id)) &&
                    ((evals[i].evaluation_state === "done") || (evals[i].evaluation_state === "conflict"))) {
                    i_am_done = true;
                }
                if ((evals[i].evaluation_state === "done") || (evals[i].evaluation_state === "conflict")) {
                    if (!(_.isNull(evals[i].score_override))) {
                        scores.push(Math.round(evals[i].score_override));
                    }
                    else {
                        scores.push(Math.round(evals[i].score));
                    }
                }
            }
            if (this.model.get("locked")) { i_am_done = true; }

            /* extract ID number from filename and compare it to make sure nothing fishy */
            var path = this.model.get("submission").file_path;
            var linked_id = path.slice(path.indexOf("/id")+3, path.indexOf("-round"));
            if (linked_id.trim() !== this.model.get("sub_id").trim()) {
                // console.log([linked_id, this.model.get("sub_id")]);
                console.log(this.model.get("sub_id") + " links to " + linked_id);
            }

            /* Extract data for export */
            // var num_evals = this.model.get("num_evals_completed"); // superceded by actual counter above
            // var combined_score = Math.round(this.model.get("combined_score"));
            // var conflict = this.model.get("submission_status") === "conflict";
            var conflict, combined_score;
            if (scores.length == 0) {
                conflict = false;
                combined_score = "•";
            }
            else {
                conflict = (Math.max(...scores) - Math.min(...scores) > 0.001);
                if (!conflict) {
                    combined_score = scores[0];
                }
                else {
                    console.log([linked_id, scores, Math.max(...scores), Math.min(...scores)]);
                    console.log(evals);
                    combined_score = "⚠";
                }
            }
            var problem_number = this.model.get("problem").attributes.display_number;
            var sub_id = this.model.get("sub_id");
            // evaluation data
            AoPS.the_eval_bucket[problem_number][sub_id] = scores.length;
            AoPS.the_conflict_bucket[problem_number][sub_id] = conflict;
            // Scoring data
            if (!(sub_id in AoPS.the_score_bucket)) {
                AoPS.the_score_bucket[sub_id] = {};
            }
            AoPS.the_score_bucket[sub_id][problem_number] = combined_score;

            var e = "admin" === this.model.get("contest").get("me").get("grader_role");
            // var e = true;
            _.extend(this.vars, {
                any_scores: (scores.length > 0), // v_Enhance added
                i_am_done : i_am_done, // v_Enhance added
                num_evals : scores.length, // v_Enhance added
                combined_score : combined_score, // v_Enhance edited
                conflict: conflict, // AoPS's is not working
                admin: e,
                sub_id: this.model.get("sub_id"),
                entry_id: this.model.get("entry_id"),
                locked: this.model.get("locked"),
                mine: this.model.get("is_mine"),
                can_claim: this.model.get("can_claim_another"),
                // conflict: "conflict" === this.model.get("submission_status"),
                status: this.model.get("submission_status"),
                submission_path: this.model.get("submission").file_path,
                evals: this.model.get("evals").map(_.bind(function(t) {
                    var i = {
                        id: t.contest_submission_evaluation_id,
                        mine: Number(t.grader_id) === Number(AoPS.session.user_id),
                        state: t.evaluation_state,
                        conflict: "conflict" === t.evaluation_status,
                        new: "new" === t.evaluation_state,
                        done: "done" === t.evaluation_state,
                        graded: "done" === t.evaluation_state || "conflict" === t.evaluation_state,
                        grader_display_name: t.grader_id ? this.model.get("contest").get("graders").get(t.grader_id).get("display_name") : "N/A",
                        score: _.isNull(t.score_override) ? Math.round(t.score) : Math.round(t.score_override),
                        comments: _.unescape(t.comments),
                        i_am_done : i_am_done,
                    };
                    return i.buttons = {
                            grade: "new" === t.evaluation_state && Number(t.grader_id) !== Number(AoPS.session.user_id),
                            edit: i.mine && "conflict" !== t.evaluation_state,
                            conflict: i.mine && "conflict" === t.evaluation_state,
                            unclaim: !t.comments && !t.score && i.mine,
                            admin_override: e && "new" !== t.evaluation_state,
                        },
                        i.labels = {
                            locked: this.model.get("locked"),
                            done: "done" === t.evaluation_state,
                            conflict: "conflict" === t.evaluation_state,
                            unavailable: "new" === t.evaluation_state && Number(t.grader_id) === Number(AoPS.session.user_id),
                            claimed: "new" !== t.evaluation_state && "done" !== t.evaluation_state && Number(t.grader_id) !== Number(AoPS.session.user_id) & "conflict" !== t.evaluation_state
                        },
                        i.is_already_claimed = !i.mine && "new" !== t.evaluation_state, i
                        // showGrader: Number(t.grader_id) !== Number(AoPS.session.user_id) && "new" !== t.evaluation_state
                }, this))
            }), this.setClassName()
        }
});

// AoPS.bootstrap_data.perms.can_edit_contest_repository = true;
// AoPS.bootstrap_data.perms.can_view_contest_repository = true;
$(document).ready(function() {
   function addGlobalStyle(css) {
        var head, style;
        head = document.getElementsByTagName('head')[0];
        if (!head) { return; }
        style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = css;
        head.appendChild(style);
    }
    addGlobalStyle("span.hidden-indiv-score { background-color: #1d3756; }");
    addGlobalStyle("span.hidden-total-score { background-color: black; }");
    addGlobalStyle("span.own-score { font-weight: bold;}");
    addGlobalStyle("div.entry-buttons { display: inline; }");
    addGlobalStyle("a.btn { display: inline; font-size: 10px; padding: 0 6px; }");
    addGlobalStyle("div.usemo-hide-content { max-width: 300px; margin: 0 auto; font-size: 10pt !important; line-height: 1.2em; }");
    addGlobalStyle("td.eval-container h5 { line-height: 1.4; font-size: 9pt; font-weight: normal; margin: 0; display: inline; }");

    $("#header-wrapper").first().append(`<div id="meow" style="text-align: center;">
    <button id="button-toggle-indiv">Indv</button>
    <button id="button-toggle-total">Aggr</button>
    <button id="button-hide-all">Hide</button>
    <button id="button-unhide-all">Show</button>
    <button id="button-progress">Prog</button>
    <button id="button-export">Expo</button>
    <button id="button-unexport">Unex</button>
    <button id="button-rg">Regrade</button>
    <button id="button-uf">Unfinalize</button>
    <div>
    <textarea id="regrade-ids" style="display:none;"></textarea>
    </div>
    </div>`);
    $("#header-wrapper").first().append(`<div id="export" style="text-align: center;"></div>`);
    $("#header-wrapper").removeClass("no-select");

    $("#button-toggle-indiv").click(function() { $(".toggle-indiv-score").toggleClass('hidden-indiv-score'); });
    $("#button-toggle-total").click(function() { $(".toggle-total-score").toggleClass('hidden-total-score'); });
    $("#button-unhide-all").click(function() { $(".usemo-hide-content").css('display', 'block'); });
    $("#button-hide-all").click(function() { $(".usemo-hide-content").css('display', 'none'); });
    $("#button-rg").click(function() { $("#regrade-ids").toggle(); });
    $("#button-uf").click(function() {
        var ids = $("#regrade-ids").val().split(/\r?\n/);
        var n = 0;
        $("tr.grader-entry").each(function(i,e) {
            if ($(e).find('td.final').length == 0) {
                return;
            }
            var m = $(e).find('td.final').length;
            if (($(e).find('.locked.conflict').length > 0)
                || ($(e).find('.usemo-hide-heading').length < 2)
                || (ids.includes($(e).find('.submission-link').html().trim()))
               ) {
                n++;
                setTimeout(function() {
                    $(e).find('.unfinalize-btn').trigger('click');
                }, 50*n);
            }
        });
        setTimeout(function() {
            var s = "Unlocked " + n + " rows.";
            if ($("#regrade-ids").val() == "") {
                s += "\n Warning: you didn't enter any regrade ID's.";
            }
            alert(s);
        }, 50*(n+1));
    });
    $("#regrade-ids").on('change', function() {
        var ids = $("#regrade-ids").val().split(/\r?\n/);
        $("#button-rg").html(ids.length);
    });

    $("#button-progress").click(function() {
        var out = `<div><small>` + new Date().toString() + `</small></div>`;
        out += `<table cellpadding="6px" style="text-align:right;">`;
        out += `<tr><th style="color:green;">Qn</th><th style="color:green;">Prcnt</th>`;
        out += `<th>0g</th><th>1g</th><th>2g</th><th>3g</th><th>X</th>`;
        out += `<th style="color:grey; text-align:center;">Total</th>`;
        out += `<th style="color:grey; text-align:center;">Done</th>`;
        out += `<th style="color:blue; text-align:center;">Left</th>`;
        out += `</tr>`;
        for (var p in AoPS.the_eval_bucket) {
            out += "<tr>";
            var ret = {0 : 0, 1 : 0, 2 : 0, 3 : 0};
            var num_conflict = 0;
            for (var s in AoPS.the_eval_bucket[p]) {
                if (AoPS.the_conflict_bucket[p][s]) {
                    num_conflict += 1;
                }
                else {
                    ret[AoPS.the_eval_bucket[p][s]] += 1;
                }
            }
            // var total = 3*(ret[0]+ret[1]+ret[2]+ret[3]+num_conflict);
            // var score = ret[1]+2*ret[2]+3*ret[3];
            var total = 2*(ret[0]+ret[1]+ret[2]+ret[3]+num_conflict);
            var score = ret[1] + 2*ret[2] + 2*ret[3];
            var percentage = Math.floor(100*(score/total));
            if (window.location.href.indexOf("jmo") > -1) {
                out += `<th style="color:green;">J` + p + `</th>`;
            }
            else {
                out += `<th style="color:green;">Q` + p + `</th>`;
            }
            out += `<th style="color:green;">` + percentage + `%</th>`;
            for (var i in ret) {
                out += `<td>` + ret[i] + `</td>`;
            }
            out += `<td>` + num_conflict + `</td>`;
            out += `<td style="color:grey;">` + total + `</td>`;
            out += `<td style="color:grey;">` + score + `</td>`;
            out += `<td style="color:blue;">` + (total-score) + `</td>`;
            out += `</tr>`;
        }
        out += `</table>`;
        alert(out);
    });

    $("#button-export").click(function() {
        var rows = [];
        for (var sid in AoPS.the_score_bucket) {
            var row = [sid];
            var sum = 0; // the sum of scores
            var num_ambiguous = 0;
            for (var n=1; n<=6; n++) {
                var score = AoPS.the_score_bucket[sid][n];
                if (typeof score === "undefined") { score = 0; }
                row.push(score)
                out += "<td>" + score + "</td>";
                if (typeof score === "number") { sum += score; }
                else { num_ambiguous++; }
            }
            row.push(sum);
            if (num_ambiguous > 0) {
                row.push(sum + 7 * num_ambiguous);
            }
            rows.push(row);
        }

        function key(row) { return -row[row.length-1]; }
        rows.sort(function (row1, row2) { return key(row1)-key(row2); } );

        var out = `<table cellpadding="6px">
        <tr>
        <th>ID</th>
        <th>P1</th>
        <th>P2</th>
        <th>P3</th>
        <th>P4</th>
        <th>P5</th>
        <th>P6</th>
        <th>&Sigma;</th>
        <th>(Max)</th>
        </tr>
        `;
        if (window.location.href.indexOf("jmo") > -1) {
            out = out.replaceAll('P', 'J');
        }
        for (var i=0; i<rows.length; i++) {
            out += '<tr>';
            for (var j=0; j<rows[i].length; j++) {
                out += '<td>' + rows[i][j] + '</td>';
            }
            out += '</tr>\n';
        }
        out += "</table>";
        $("#export").html(out);
    });

    $("#button-unexport").click(function() {
        $("#export").html('');
    });
});
