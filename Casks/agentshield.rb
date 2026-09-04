cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2037"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2037/agentshield_0.2.2037_darwin_amd64.tar.gz"
      sha256 "911a4f3664da92858237eb7ab504ff0349df45e4361b0d214c09ab3121042b04"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2037/agentshield_0.2.2037_darwin_arm64.tar.gz"
      sha256 "2f42e00b60cf946b13ebe9a7376adf27cd38a91212991b0cc8daebaf866bb59a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2037/agentshield_0.2.2037_linux_amd64.tar.gz"
      sha256 "d0c2446c52b8f760b6568c51b739209cd0943a36659f1cbc9abcb59cfa75685c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2037/agentshield_0.2.2037_linux_arm64.tar.gz"
      sha256 "5c6a8640abb1440c256c2174e6a71294e53b64e681feb136171667ad35ad459c"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
