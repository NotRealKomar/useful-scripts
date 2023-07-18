## REQUIREMENTS:
* .env file must end with a newline;
* Add the generated file (**environment.generated.ts** by default) to **.gitignore**;
* Update your **angular.json** file with the following lines (replace paths with your own):
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

## ///TODO///