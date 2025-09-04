1. When adding code don't add comments unless the comment has information that is not encoded in the code. This is very important! Instead create separate named methods if necessary.  However, keep existing comments.

2. You may use `add_vscode_bookmark '/path/file:line' 'Label'` after doing a complexer code
 research to mark mentioned locations. For marking source files in the iOS folder you can use `add_xcode_bookmark '/path/file:line' 'Label'`. But for .plist and .entitlements you can't use it and need to fallback on `add_vscode_bookmark`.

**Label format:** `Number. from-to: Description (file)`
- Number for organization
- Brief description of purpose

**Example:**
```bash
add_xcode_bookmark '/path/Info.plist:32' '1. 32-34: Network permissions settings (Info.plist)'
add_vscode_bookmark '/path/AuthService.ts:145' '2. 145-159: JWT token validation logic (AuthService.json)'
```
