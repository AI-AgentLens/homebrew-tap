cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1955"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1955/agentshield_0.2.1955_darwin_amd64.tar.gz"
      sha256 "f9562abe7d0fe0d7cf3b5230caecd9f719b12aee02e151e80d686dc0415ece08"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1955/agentshield_0.2.1955_darwin_arm64.tar.gz"
      sha256 "88158afb437982a6ca37454e91b1d2e8729bd67b49cd995648d3a3669f52ea7b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1955/agentshield_0.2.1955_linux_amd64.tar.gz"
      sha256 "fb2210179dac1a8b6e81753624db5ccc7a4cba3f9758735010423e82dad30a5d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1955/agentshield_0.2.1955_linux_arm64.tar.gz"
      sha256 "9c21fe7e84634394f8ce3a4ee634c9f7529aa9daa0b004ce69487a5118d009a2"
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
