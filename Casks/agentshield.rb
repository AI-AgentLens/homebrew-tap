cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.764"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.764/agentshield_0.2.764_darwin_amd64.tar.gz"
      sha256 "4538bf6aca91765b9284e6e1524f989c7b4f7029a36a1c235fe4a7af01628fc5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.764/agentshield_0.2.764_darwin_arm64.tar.gz"
      sha256 "adce42515cf678ed766b7f57a38b71dac623b648f402e76838c6d5d923ea2871"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.764/agentshield_0.2.764_linux_amd64.tar.gz"
      sha256 "dfb09a75344e8f7f314cbfbce72e9a69e0164e9e82d3a72408ad8d9e0fee75ef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.764/agentshield_0.2.764_linux_arm64.tar.gz"
      sha256 "d86a0171a3c0968f903bdb792a6ba143b6fbf53b0d666a3a390a7f8e9ff3cd55"
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
