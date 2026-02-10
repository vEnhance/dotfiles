#!/usr/bin/env python3

from tasklib import Task


def hook_github_unhalt_if_updated(task: Task):
    if (github_updated_at := task["githubupdatedat"]) and (
        halted_on := task["haltedon"]
    ):
        if github_updated_at > halted_on:
            task["haltedon"] = None
            task["wait"] = None
            print(
                f"Unhalting the task {task['githubrepo']}#{round(task['githubnumber'] or 0)} since it was updated at {github_updated_at}."
            )
