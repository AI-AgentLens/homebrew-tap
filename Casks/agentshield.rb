cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1718"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1718/agentshield_0.2.1718_darwin_amd64.tar.gz"
      sha256 "638cc0b98c79d011264b460f850807fe799aa39b59fc144624075d51afac5665"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1718/agentshield_0.2.1718_darwin_arm64.tar.gz"
      sha256 "69923e15f9850fde5c4badfd93268953b9f3d65b36cc4b2e4cb6287cfff8d21e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1718/agentshield_0.2.1718_linux_amd64.tar.gz"
      sha256 "2d983aec947e20f9bc80aef1d2f5dab1dffe9e128160c6fd7c23aa1a7b133675"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1718/agentshield_0.2.1718_linux_arm64.tar.gz"
      sha256 "3b850d310958418bae0108115724999b14a7ff164cadfd8535b11258bfdd8858"
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
