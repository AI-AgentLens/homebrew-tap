cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1146"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1146/agentshield_0.2.1146_darwin_amd64.tar.gz"
      sha256 "da69f3c511fd85afe4d0624f20627de8a9bd00b70859da78eb793ccfeab7421b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1146/agentshield_0.2.1146_darwin_arm64.tar.gz"
      sha256 "1d030987315f14c8f531fe241bc01191281376fcf369aaac5f552e596e5cff55"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1146/agentshield_0.2.1146_linux_amd64.tar.gz"
      sha256 "d17d699e51e99dd39c127684dc801a5c4b891911f645bc28d2d12b1a1568a207"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1146/agentshield_0.2.1146_linux_arm64.tar.gz"
      sha256 "5de3dcd1552d7784ee515eed228819720626b539c7e71ddcb5ef4ad8c9802327"
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
