cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1081"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1081/agentshield_0.2.1081_darwin_amd64.tar.gz"
      sha256 "a420d020c0797cd51c44d7de82f89edf0bb437e4b577a07a4cf9a75560d69298"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1081/agentshield_0.2.1081_darwin_arm64.tar.gz"
      sha256 "e9e1223ba1a25d062c4eb5959b99867dc2b8106954a1336828dee5e396f5d3bb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1081/agentshield_0.2.1081_linux_amd64.tar.gz"
      sha256 "ce64d2032b04c2dc5d30c4679399637d30a49938bcd49f0029696a0c7af9320e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1081/agentshield_0.2.1081_linux_arm64.tar.gz"
      sha256 "3f4fceabfb7903edc19784bf4d0c286fd45ade0465bfc32007cf3dc81bff8776"
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
