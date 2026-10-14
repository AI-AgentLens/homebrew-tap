cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2431"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2431/agentshield_0.2.2431_darwin_amd64.tar.gz"
      sha256 "40f872c5cfe64b86775324ab0d5febfbae073d057ea740a374494a8775a48448"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2431/agentshield_0.2.2431_darwin_arm64.tar.gz"
      sha256 "ae50aa2dcd92f2332d42185c7b5af68db5f033b93ef0aa23cbab4663ea620ccb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2431/agentshield_0.2.2431_linux_amd64.tar.gz"
      sha256 "f40964822ef7bcb8b3dbcc1c651bcfced35dc9becbf20055e8d5f14605da69cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2431/agentshield_0.2.2431_linux_arm64.tar.gz"
      sha256 "76a03eb1a46aadfb604939640d0a2cb156f204b5ca14441bef0c7fee129dcacd"
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
