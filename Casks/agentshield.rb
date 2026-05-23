cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1103"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1103/agentshield_0.2.1103_darwin_amd64.tar.gz"
      sha256 "f7094fcc59f862e88f5f6e9927eeb7d5bae21ef26fb52ccdfe6b851b14161fd0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1103/agentshield_0.2.1103_darwin_arm64.tar.gz"
      sha256 "1bb8d1e9d29e4855494f4a51d3b9bb36c5ca1e1b010618df912c396a627aadb1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1103/agentshield_0.2.1103_linux_amd64.tar.gz"
      sha256 "c32cfea6d760e1bfe2bd06909793af9f9bf5dcda1da757b3e5bea6c8882ce0c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1103/agentshield_0.2.1103_linux_arm64.tar.gz"
      sha256 "d5b34122ffae67ac8cf4a54ef90e2326c6174af088271e0e6d3aff18252edea2"
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
