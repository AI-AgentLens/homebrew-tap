cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1721"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1721/agentshield_0.2.1721_darwin_amd64.tar.gz"
      sha256 "97083a7ae7fdfd4f781acc0d5701c5cee4647b220a6a8eee19434391bc2af303"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1721/agentshield_0.2.1721_darwin_arm64.tar.gz"
      sha256 "e3323b2a1fa7429a63f474370728b1ef53ac6e362e350dde432d29b6a1a82e9c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1721/agentshield_0.2.1721_linux_amd64.tar.gz"
      sha256 "352f7925079cb14604ef7e5ea0403a58dcedb3963495a791ecdba6b1c31de2fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1721/agentshield_0.2.1721_linux_arm64.tar.gz"
      sha256 "eb6957cfdd8e8360c2be6418542d02297f35a4cb29e749eb3dc02563b87215bb"
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
