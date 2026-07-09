cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1596"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1596/agentshield_0.2.1596_darwin_amd64.tar.gz"
      sha256 "15a2f32d30ad004435db9420d3565eeabec98b9068cdb091ba416e08544ac2c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1596/agentshield_0.2.1596_darwin_arm64.tar.gz"
      sha256 "9d487af6bfba0885d8d9d0083fcdd4965a41596b77b7de64bb4d68a9ebae6d8e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1596/agentshield_0.2.1596_linux_amd64.tar.gz"
      sha256 "c497ddd6420e1d4cc85373b538a2ded6a0e43085a9ee51a24945f666a5cc5a34"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1596/agentshield_0.2.1596_linux_arm64.tar.gz"
      sha256 "6d5765d2e679a5f50169dcedadc93b993a4c3c14272f30ee478cd7cbed5ed78c"
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
