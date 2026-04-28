cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.794"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.794/agentshield_0.2.794_darwin_amd64.tar.gz"
      sha256 "cf3103b247b18cdf4ea5ab493f2eb75bbc76cead3e04d99bf7c580c75721ba3a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.794/agentshield_0.2.794_darwin_arm64.tar.gz"
      sha256 "a8772778498cb7ce360128ebfeb370bcbae6980c9ab0ebf20ff71c7988ee298a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.794/agentshield_0.2.794_linux_amd64.tar.gz"
      sha256 "0a2cd22f3f5f532379b0554487aaaab5a3e0d79762b0aee4bc9aeecc1411cfcc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.794/agentshield_0.2.794_linux_arm64.tar.gz"
      sha256 "894a6dc69be439a91b0c7c2b9040a955e01bf8f56dcb954205b69d2b8740f6ff"
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
