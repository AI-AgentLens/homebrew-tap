cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1043"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1043/agentshield_0.2.1043_darwin_amd64.tar.gz"
      sha256 "050264fdc42db9dbd92023be1270373a0f57b5edb7c4095356d5978a5e023a41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1043/agentshield_0.2.1043_darwin_arm64.tar.gz"
      sha256 "5b3872131c99330ddc8a496745a9e96e2388e512df97f97e2da6a4ba0a1d1f80"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1043/agentshield_0.2.1043_linux_amd64.tar.gz"
      sha256 "2120b43cd276a4256fe53dc67034621c6c8e2fd8fcdd9de1529a190b857da330"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1043/agentshield_0.2.1043_linux_arm64.tar.gz"
      sha256 "4c3cf01013c04fac45e1e0ce36699b4ca9e218ee785dbd315512f8d2601b2595"
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
