<claude_spec version="1.0">
  <meta>
    <title>CLAUDE Code & Bookmark Policy</title>
    <audience>Contributors</audience>
  </meta>

  <policies>
    <policy id="comments">
      <summary>Do not add code comments unless they contain information not encoded in code. Keep existing comments.</summary>
      <rules>
        <rule>When adding code, omit comments that only restate what the code expresses.</rule>
        <rule>If necessary, create small, named methods to encode intent instead of comments.</rule>
        <rule>Preserve all existing comments in touched files.</rule>
      </rules>
    </policy>

    <policy id="bookmarks">
      <summary>Use editor bookmark helpers to mark findings after deeper code research.</summary>
      <tools>
        <tool name="vscode">add_vscode_bookmark '/abs/path/file:line' 'Label'</tool>
        <tool name="xcode">add_xcode_bookmark '/abs/path/file:line' 'Label'</tool>
      </tools>
      <constraints>
        <constraint>For files under iOS, prefer <toolref name="xcode"/>.</constraint>
        <constraint>For .plist and .entitlements, <toolref name="xcode"/> is unsupported; use <toolref name="vscode"/>.</constraint>
      </constraints>
      <label_format>
        <pattern>{Number}. {from}-{to}: {Description} ({file})</pattern>
        <guidelines>
          <guideline>Use a sequential Number for organization.</guideline>
          <guideline>Keep Description brief and purpose-focused.</guideline>
        </guidelines>
      </label_format>
    </policy>
  </policies>

  <examples>
    <example id="bookmark-ios">
      <context>Bookmarking Info.plist settings</context>
      <commands>
        <cmd>add_vscode_bookmark '/path/Info.plist:32' '1. 32-34: Network permissions settings (Info.plist)'</cmd>
      </commands>
    </example>

    <example id="bookmark-ts">
      <context>Bookmarking token validation logic</context>
      <commands>
        <cmd>add_vscode_bookmark '/path/AuthService.ts:145' '2. 145-159: JWT token validation logic (AuthService.ts)'</cmd>
      </commands>
    </example>
  </examples>

  <formatting_notes>
    <note>Use absolute paths where possible.</note>
    <note>Use 1-based line numbers as displayed in the editor.</note>
  </formatting_notes>
</claude_spec>
