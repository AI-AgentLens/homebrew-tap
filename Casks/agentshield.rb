cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1487"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1487/agentshield_0.2.1487_darwin_amd64.tar.gz"
      sha256 "66825b67925b92bd45ff2dba1e51715e4ea363e7b7ba23e07709764dd8ec523c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1487/agentshield_0.2.1487_darwin_arm64.tar.gz"
      sha256 "fa9f166bde99193fee310894a74ced3e7033250684e21f9f277852999ca18122"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1487/agentshield_0.2.1487_linux_amd64.tar.gz"
      sha256 "9af8190c87f1ae790a5375b99c14ac6839bffeb2bf2a6982f5e47f770fea3e0b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1487/agentshield_0.2.1487_linux_arm64.tar.gz"
      sha256 "9595b789de5bc58fe58258f5ada000013ab01b44b15a0cf7ea1e635399b48202"
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
