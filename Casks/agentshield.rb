cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1819"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1819/agentshield_0.2.1819_darwin_amd64.tar.gz"
      sha256 "bda561e18b8cd4a1f69dade0a1ed3d8f3b17904b08f725b506b75373c72cf6d7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1819/agentshield_0.2.1819_darwin_arm64.tar.gz"
      sha256 "8cfe2407909538f3b4879ea69b8b18dd4e5095100227fc65482261fe2cf2ef48"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1819/agentshield_0.2.1819_linux_amd64.tar.gz"
      sha256 "e339148d04a87efd33a82566f194245596a531ff254f4e02b752a212e16667d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1819/agentshield_0.2.1819_linux_arm64.tar.gz"
      sha256 "c8355b7caf7141abd8975216064918f4eeab60aecc27e20a930aaf1b00fd5a28"
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
