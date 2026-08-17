cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1890"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1890/agentshield_0.2.1890_darwin_amd64.tar.gz"
      sha256 "ab4a3c41805c401a9506df07ebc1d87a4216d216540ba440606a2fb75b3472df"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1890/agentshield_0.2.1890_darwin_arm64.tar.gz"
      sha256 "a5dda294dd8ab8fd1866589c136b9e8e3692d4f7544b3a6361d7bd4731918ea0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1890/agentshield_0.2.1890_linux_amd64.tar.gz"
      sha256 "687300ab092e9f3ea96ec9c0ddca9e6071e1579a8216c0119c82ee5548a499a0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1890/agentshield_0.2.1890_linux_arm64.tar.gz"
      sha256 "e241de22839596fa56fe4e80bc77a8a5273155888d2525882584d8426cfe1d1d"
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
