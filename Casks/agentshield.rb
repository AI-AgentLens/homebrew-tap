cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1297"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1297/agentshield_0.2.1297_darwin_amd64.tar.gz"
      sha256 "6ab79e12b1a181429be3387a15d761b2c59a31d35e2d45f467efca168a7dade8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1297/agentshield_0.2.1297_darwin_arm64.tar.gz"
      sha256 "c0588168a7d55165cb75de012a59a017026f77fff76635804535d05ee16b3eaa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1297/agentshield_0.2.1297_linux_amd64.tar.gz"
      sha256 "ac7a147805b4aa445e0cbcd163296323fb1adc06e2efa489b1c1dbf8acb94d03"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1297/agentshield_0.2.1297_linux_arm64.tar.gz"
      sha256 "7feb4f27558c2c04ee79178c923bb513f90b9b39fa28626b87cebfef09d30658"
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
