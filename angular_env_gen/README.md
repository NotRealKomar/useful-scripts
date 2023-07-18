
## NOTES:
After adding the script, don't forget to update your angular.json file with the following lines (replace paths with your own):
```json
"architect": {
  ...
  "configurations": {
    ...
    "fileReplacements": [
      {
        "replace": "src/environments/environment.ts",
        "with": "environment.generated.ts"
      }
    ]
  }
}
```
And add the generated file to .gitignore

### TODO