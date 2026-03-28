cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.169"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.169/agentshield_0.2.169_darwin_amd64.tar.gz"
      sha256 "382f1a483aed048326c9dc4df26c15644a850c5508ab8a9a442a3a8446b89281"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.169/agentshield_0.2.169_darwin_arm64.tar.gz"
      sha256 "b8b516fb261a4ca5b33aa8254008505617d5c09bf9d52ef048dad4cee936cde9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.169/agentshield_0.2.169_linux_amd64.tar.gz"
      sha256 "9cce9515e0de10a167c861986168db3da7282e9b38205732ff9d33e7c17c009c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.169/agentshield_0.2.169_linux_arm64.tar.gz"
      sha256 "1a4282577567024918cf958ee5fb2158f990d1f50b7db175099a78f9aa869413"
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
