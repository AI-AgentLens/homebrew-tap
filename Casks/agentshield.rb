cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1503"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1503/agentshield_0.2.1503_darwin_amd64.tar.gz"
      sha256 "839533aa9c09f4fee8248b9b01d5229250bef69d05964bc6d5d977d5625ead61"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1503/agentshield_0.2.1503_darwin_arm64.tar.gz"
      sha256 "92f15d09f0c9267cc24de6366f473a054f5ca4a176294a7695fdd0dd658590a5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1503/agentshield_0.2.1503_linux_amd64.tar.gz"
      sha256 "96e58fc7437f7ec4c75eee4d05539c83f2ac970e05314a42a31a2e88831889dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1503/agentshield_0.2.1503_linux_arm64.tar.gz"
      sha256 "62ef04083573bb20b6dc35c9667bf7c5eac9576f7a4e1e5fe8cd35c4293484f7"
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
