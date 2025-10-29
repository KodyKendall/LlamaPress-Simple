You can generate release notes by running this command:

git diff $OLD $NEW --unified=0 > diff.patch

Then, you can create new release notes in docs/release-notes folder for the specific version. Here's the prompt to use: 


Release Notes Prompt:
<PROMPT>
Project Name: LlamaPressSimple
Release Version: <version>

Here is a Git diff between two commits. Please read the changes and document this for our release notes! in our docs/release-notes, put it into an HTML format that's easy to copy+paste into Github release notes. Describe what the changes do, and why they're important! Use light and subtle emojis and good design for improved readability.

--- START OF DIFF ---
{diff.patch}
--- END OF DIFF ---

Here are additional devlogs for this:
___ START OF DEV LOGS ___
{docs/<version>}
___ END OF DEV LOGS ___
</PROMPT>
```