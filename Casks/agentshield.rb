cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.462"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.462/agentshield_0.2.462_darwin_amd64.tar.gz"
      sha256 "bd56bb0efea9d3a4b0b14ba16f97b527ace50e622d27e24c615a82730546480c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.462/agentshield_0.2.462_darwin_arm64.tar.gz"
      sha256 "1c46209a52859a059fd3196d34ec7865bb910ee2f84210906421d6bc5cf7dfe9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.462/agentshield_0.2.462_linux_amd64.tar.gz"
      sha256 "e6de2850532923b5507de0a5dc1934f8fd0c2fab8899974b1c04aecedbb0d54a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.462/agentshield_0.2.462_linux_arm64.tar.gz"
      sha256 "4f0dbf36d7493486fe42ad29d019508392430de8aedd4f4caf0c382fe1124a29"
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
