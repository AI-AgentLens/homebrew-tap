cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.805"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.805/agentshield_0.2.805_darwin_amd64.tar.gz"
      sha256 "025f5d44ea9355e750df3f3915a5eda49e700470b21c8262ed8f47bb6b501fd5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.805/agentshield_0.2.805_darwin_arm64.tar.gz"
      sha256 "ecd26060dd4e0a77e261d6e8261457f87158d7ac656aad09cd4450013b342ecf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.805/agentshield_0.2.805_linux_amd64.tar.gz"
      sha256 "bad6ab2245a80a5ad5043224294ec420db94055690175fdd5e0ca39ac147db57"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.805/agentshield_0.2.805_linux_arm64.tar.gz"
      sha256 "fe6a9327269daaba5c3105c8ac98bf1d305183638b153ba14ffd3213003b5441"
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
