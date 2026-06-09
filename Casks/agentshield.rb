cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1261"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1261/agentshield_0.2.1261_darwin_amd64.tar.gz"
      sha256 "6da6ae031ead3f7b208d8540c64f03acc0e4b60507834eccc175a7438609a836"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1261/agentshield_0.2.1261_darwin_arm64.tar.gz"
      sha256 "8e8b8200ddfbe85e31b39f16515220f7b3a78f4892c84c7f90de28c38193a1b2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1261/agentshield_0.2.1261_linux_amd64.tar.gz"
      sha256 "7232d3a3b8184d262af6569f0e18673d60e0dbcdbb101b8015d80ea303f711aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1261/agentshield_0.2.1261_linux_arm64.tar.gz"
      sha256 "afd8c83bbb2dc11f5f30935c90a4061f8740e6eb383296ff4fd010466e6f185a"
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
