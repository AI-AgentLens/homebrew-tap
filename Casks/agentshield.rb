cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.242"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.242/agentshield_0.2.242_darwin_amd64.tar.gz"
      sha256 "0c114ca976f777d0474d884128cf91be04d6497b057b2284b9ebc59d6796dd73"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.242/agentshield_0.2.242_darwin_arm64.tar.gz"
      sha256 "5c1968ecc00b762f8f9b17d127c251b42d665b49bb1134e380d0fdde76c0d5b4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.242/agentshield_0.2.242_linux_amd64.tar.gz"
      sha256 "d16bfa4742c918859f24c9d60ef276db5f71d975276aad76322eeb72995e0930"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.242/agentshield_0.2.242_linux_arm64.tar.gz"
      sha256 "06671ea1a9a757bfdc1db2ed3b58463ffe40c6d44da1cf5bf0cb2d6dbe748f67"
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
