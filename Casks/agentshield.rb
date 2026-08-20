cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1908"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1908/agentshield_0.2.1908_darwin_amd64.tar.gz"
      sha256 "94300eea77d7ad395cccd0fd02dbaf99e35d50ec13382718d1e1ae954273c725"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1908/agentshield_0.2.1908_darwin_arm64.tar.gz"
      sha256 "5153c84fd3a9ca6570284fb917b8e60eff544c8f31ea4f12523a83d361884886"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1908/agentshield_0.2.1908_linux_amd64.tar.gz"
      sha256 "c7b736d17800f421452c95d0b444111f28b787e8a9d3e824a15bc971167491da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1908/agentshield_0.2.1908_linux_arm64.tar.gz"
      sha256 "ae16ceefa62907ec083d26ace51be9e06be8b921f403ea2e7f05958ee3aec1ba"
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
