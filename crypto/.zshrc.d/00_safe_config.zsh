# Hardening secure commands.
# Prevent internet access and logging to Console.app
alias nonet='sandbox-exec -p "(version 1)(allow default)(deny network*)(allow network-outbound (to unix-socket))(allow network-inbound (from unix-socket))(allow mach-lookup (global-name \"com.apple.cfprefsd.*\"))(allow mach-lookup (global-name \"com.apple.system.notification_center\"))(debug deny)"'
alias gpg='nonet gpg'
alias gpg-agent='nonet gpg-agent'
alias oathtool='nonet oathtool'
alias ripsecrets='nonet ripsecrets'
alias ssh-keygen='nonet ssh-keygen'
