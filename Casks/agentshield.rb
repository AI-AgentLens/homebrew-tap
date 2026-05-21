cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1064"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1064/agentshield_0.2.1064_darwin_amd64.tar.gz"
      sha256 "9042f28f52ab99176fb502580d02781585bec26105981ab8e60ddcf156d02ae1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1064/agentshield_0.2.1064_darwin_arm64.tar.gz"
      sha256 "f87039ffe7176f58e08d26ff484e1f808039eaade5f63c89e623fa40b34c69e1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1064/agentshield_0.2.1064_linux_amd64.tar.gz"
      sha256 "03db70f1fde66c2d8abedf25fbef46aaa62b70860174f916b8d332f436f44220"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1064/agentshield_0.2.1064_linux_arm64.tar.gz"
      sha256 "e90a605c094eceb5291627ea4bba81e7c07d52e4716e09256e66fcc430f914c9"
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
