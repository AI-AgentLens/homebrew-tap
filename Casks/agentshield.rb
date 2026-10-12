cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2410"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2410/agentshield_0.2.2410_darwin_amd64.tar.gz"
      sha256 "ce16e275db24e1110c984dd2dff69a18e706c433be0373358c4dabd02b5ce7e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2410/agentshield_0.2.2410_darwin_arm64.tar.gz"
      sha256 "8ba4b0a4c8df5e4de3906cfa8fd105df25d9f5527063686fd6866bb9571ec42a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2410/agentshield_0.2.2410_linux_amd64.tar.gz"
      sha256 "b054151bcb83e73267b9321568296d516a50d35c6ad51a34ed53342eaf705613"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2410/agentshield_0.2.2410_linux_arm64.tar.gz"
      sha256 "b8d0fecbcd8d9a0dd265ad054586eb406be0ef90fa224b22df3d04f84d685b38"
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
