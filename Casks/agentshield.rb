cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.106"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.106/agentshield_0.2.106_darwin_amd64.tar.gz"
      sha256 "fe3c6639abcbffa8edfd93f3b9d532f5ef08bd03de5c3113df08692e8863146c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.106/agentshield_0.2.106_darwin_arm64.tar.gz"
      sha256 "7ea2d7fb55219374e515bb08a22d55499ee980272f403ea35b5b44f42dda8aa3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.106/agentshield_0.2.106_linux_amd64.tar.gz"
      sha256 "a86d836471fbf0daa643ba605b047c43e21d0def73370a44e78f8630a76bca8b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.106/agentshield_0.2.106_linux_arm64.tar.gz"
      sha256 "12baf5187b4ba5c56796cbbacf3c3ba7bbe9624653e8669046eed12c622d05a9"
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
