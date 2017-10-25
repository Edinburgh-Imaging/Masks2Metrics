# Contribution Guidelines

## Reporting issues

- **Search for existing issues.** Please check to see if someone else has reported the same issue.
- **Share as much information as possible.** Include operating system and version, browser and version. Also, include steps to reproduce the bug.

## Project Setup
Refer to the [README](README.md).

## Code Style

### Variable Naming
Not all current code follows the conventions below but these will be followed for future developments. 
- `lower_camel_case` General variables
- `lower_camel_case` Functions
- Maximize the use  of semantic and descriptive variables names (e.g. `gyrus_slice` not `g_sl` or `gs`). Avoid abbreviations except in cases of industry wide usage. In some cases non-descriptive and short variable names are exceptable for instance vertices (points), faces, edges, colors and logic arrays may be denoted `v`, `f`, `e`, `c`, `l`. Furthermore, if a mathematrical symbol or letter is commonly used for some entity it may be acceptable to use short names e.g. coordinates may be referred to as `x`, `y` and `z` and image coordinates of indices may be referred to as `i`, `j` and `k`.

## Testing

For more details, please refer to our _[Wiki](https://github.com/Edinburgh-Imaging/Masks2Metrics/wiki)_. It includes:
 * a _[short tutorial](https://github.com/Edinburgh-Imaging/Masks2Metrics/wiki/Short-tutorial)_ demonstrating how the tool can be used in general and to run the given [example](https://github.com/Edinburgh-Imaging/Masks2Metrics/tree/master/example.zip)_ 
 * a _[workflow](https://github.com/Edinburgh-Imaging/Masks2Metrics/wiki/Workflow)_ highlighting communication between all functions

## Pull requests
- Try not to pollute your pull request with unintended changes – keep them simple and small. If possible, squash your commits.
- Try to share how your code has been tested before submitting a pull request.
- If your PR resolves an issue, include **closes #ISSUE_NUMBER** in your commit message (or a [synonym](https://help.github.com/articles/closing-issues-via-commit-messages)).
- Review
    - If your PR is ready for review, another contributor will be assigned to review your PR
    - The reviewer will accept or comment on the PR. 
    - If needed address the comments left by the reviewer. Once you're ready to continue the review, ping the reviewer in a comment.
    - Once accepted your code will be merged to `master`