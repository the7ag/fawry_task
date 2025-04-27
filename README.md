Okay, here are your answers with Markdown formatting, keeping your original text style and wording:

## 1. A breakdown of how your script handles arguments and options.

The script uses the built-in bash command `getopts` for handling the options. The default values for the options (```showLineNumber```, ```invertMatch```) is false. The ```--help``` it checks for the first options using this specific check `[[ "$1" == "--help" ]]` and it handles help before the options by displaying a usage message. The ```getopts``` loop loops on the processes options (-n,-v). The leading colo enables silent error handling, and we can catch them later via the \? case. For each option found, we turn the flag corresponding to it into true. Iff an invalid option is encountered, we display an error message, and we print the usage function. The `shift((OPTIND -1))` after the loop shift removes the processed options and their arguments from the positional parameters. Thiss makes "$1" the first nonoptional arg and "$2" the second. Argument vvalidationwe check if thethere areactly two position args remaining, if not, print an error message. Afterr that, we assign the arguments to variables and do some file checks to see if it's created andalsos if it's readable.

## 2. If you were to support regex or -i/-c/-l options, how would your structure change?

Supporting more options from the original grep like -c (count) or -l (list files) would significantly change the script structure like -c would replace printing lines with a final count, while -l would necessitate an outer loop to handle multiple files printing only filename if any match is found within that file. And for supporting regex, we can use a more powerful mechanism like sed and aw,k likely using bash's `[[ =~ ]]`.

## 3. What part of the script was hardest to implement and why?

Usingng getopts for handling options, Ii didn't figure out how to shift the positional parameter,s but theI i found out about optind and used it for moving the parameters after using it.