cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.857"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.857/agentshield_0.2.857_darwin_amd64.tar.gz"
      sha256 "e1d8e9f4de7e8326e05f3851303e655ae317888fd8d21c7c07cc0b41be715ad5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.857/agentshield_0.2.857_darwin_arm64.tar.gz"
      sha256 "0f71bb876edbe66e189c98858ffdf2387d0faccebe7c2b25a2e0b75b17267cc7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.857/agentshield_0.2.857_linux_amd64.tar.gz"
      sha256 "b6626b5385961c7b4f5f7206be1132ea1159c00d17a0c862c2eee144fbd57a76"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.857/agentshield_0.2.857_linux_arm64.tar.gz"
      sha256 "997aee61a491888eb8f558327547fd008236d3e934c1a4fa9fe73cd0d68998b7"
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
