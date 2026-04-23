cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.693"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.693/agentshield_0.2.693_darwin_amd64.tar.gz"
      sha256 "18411ba90834002c916763ca2f3834a4cf0926ce7a4761dfee056d57a302ac1b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.693/agentshield_0.2.693_darwin_arm64.tar.gz"
      sha256 "29698815962b3b572b4cd009821a5959f8ddcf13673038db5efdc6d52e8c026f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.693/agentshield_0.2.693_linux_amd64.tar.gz"
      sha256 "9bf12ba4ada1e482f120188641f77d2628412d08459174eea84c1c4d23dcd4ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.693/agentshield_0.2.693_linux_arm64.tar.gz"
      sha256 "5e8e59f8dba89569153217bb54139c87170f70cb803d6de07204c78fb657c760"
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
