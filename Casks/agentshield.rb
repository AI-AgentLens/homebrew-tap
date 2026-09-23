cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2231"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2231/agentshield_0.2.2231_darwin_amd64.tar.gz"
      sha256 "66aeef521ea96dca8d6f48897ebd61cba5a6b2c49c88c0d36b700ad8c5d24228"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2231/agentshield_0.2.2231_darwin_arm64.tar.gz"
      sha256 "1d7d6787becd80275ad534c59542ea9a209f11c18cf991b69b051e909d7c316b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2231/agentshield_0.2.2231_linux_amd64.tar.gz"
      sha256 "99931feb660bf06e8e494f545b06168b9dba41ec5d2de370e6877de1eca78af2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2231/agentshield_0.2.2231_linux_arm64.tar.gz"
      sha256 "e35441fc5649c96cec6295966d9eeff670b7a6482d906fa14fc35041c1cb5d11"
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
