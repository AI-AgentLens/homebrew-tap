cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1386"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1386/agentshield_0.2.1386_darwin_amd64.tar.gz"
      sha256 "db5909271a21b2ee0dcb2886f61a484f0758d190ebb890a57b04ecbc98a2680f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1386/agentshield_0.2.1386_darwin_arm64.tar.gz"
      sha256 "ab2b93a5afd150d4820811990fcd81973390ac9a11dbcc04a138bde00482053a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1386/agentshield_0.2.1386_linux_amd64.tar.gz"
      sha256 "b488b87f15ebacce4294eb1e6b4b71e59d38ffe9cc68e6520a543a8972efb9de"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1386/agentshield_0.2.1386_linux_arm64.tar.gz"
      sha256 "25ee07fe5520c6f4cbac9245467980bfcf374e243ed9582ca21639ca84fce79c"
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
