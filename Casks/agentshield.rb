cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1002"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1002/agentshield_0.2.1002_darwin_amd64.tar.gz"
      sha256 "545a520433ea05bf8ccefa6b30c5d16f11530ae675bd83eafd5c8cd3f43845f8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1002/agentshield_0.2.1002_darwin_arm64.tar.gz"
      sha256 "e180916ebc6b165bf9ba6bda7dc21f0790a005304f9813ecf40f9e24eeb59a44"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1002/agentshield_0.2.1002_linux_amd64.tar.gz"
      sha256 "1f0196c104c256336b2c60451f443044948a8aa1f215d1ee37d869ce6a9654ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1002/agentshield_0.2.1002_linux_arm64.tar.gz"
      sha256 "4f86b6bfd310d4f647232f088083173f08dcaf65180ce8feb06c6a4cc5dada14"
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
