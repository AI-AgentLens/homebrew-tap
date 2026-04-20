cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.664"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.664/agentshield_0.2.664_darwin_amd64.tar.gz"
      sha256 "64622efd254e596b0a60360c6d8c2748911a448ce6a8a535dcd28e35639d3c1b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.664/agentshield_0.2.664_darwin_arm64.tar.gz"
      sha256 "07a3243b7c27deb010dea968545a185545da38a7bb3e2922ad213f067b815238"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.664/agentshield_0.2.664_linux_amd64.tar.gz"
      sha256 "3aca8fd0a6d7e27d57e975b22932be147a26bd11dd07e568f4b0d489ca9a839d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.664/agentshield_0.2.664_linux_arm64.tar.gz"
      sha256 "46dc87d175a0329e84e0c8fa688d0f56dd4582a1bc8f057de5944c46cbd4cf56"
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
