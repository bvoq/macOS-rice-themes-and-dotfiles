1. When adding code don't add comments unless the comment has information that is not encoded in the code. This is very important! Instead create separate named methods if necessary.  However, keep existing comments.

2. You may use `add_vscode_bookmark '/path/file:line' 'Label'` after doing a complexer code
 research to mark mentioned locations.

**Label format:** `Number. (V|X from-to) Description (file)`
- V = VSCode, X = Xcode (files in ios folder)
- Number for organization
- Brief description of purpose

**Example:**
```bash
add_vscode_bookmark '/path/Info.plist:32' '1. (X 32-34) Network permissions settings (Info.plist)'
add_vscode_bookmark '/path/AuthService.ts:145' '2. (V 145-159) JWT token validation logic (AuthService.json)'
```
