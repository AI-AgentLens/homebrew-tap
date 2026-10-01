cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2308"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2308/agentshield_0.2.2308_darwin_amd64.tar.gz"
      sha256 "b3e81fce6b622b6a10dbcb6f855436db72aa9393c0d83f2e6b9954450fd69475"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2308/agentshield_0.2.2308_darwin_arm64.tar.gz"
      sha256 "00ea2ed8bec090d04daff4508bd1f37fdce68e87826a2157d1c646f3c28a86f2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2308/agentshield_0.2.2308_linux_amd64.tar.gz"
      sha256 "6fbdf93bd304aca7513066ad575d005209dc3ce7d4c5ceba595277f65c3abf47"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2308/agentshield_0.2.2308_linux_arm64.tar.gz"
      sha256 "ee544999febe0ac6fb3cf23d0a50eb8dd80cdb1bcda49bbb3ac7fa76c03e9c8c"
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
