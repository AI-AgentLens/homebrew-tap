cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1984"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1984/agentshield_0.2.1984_darwin_amd64.tar.gz"
      sha256 "3a16ae20ed9166c8e80af07fb78ea83c4f4b3f92f10df123e43f4240354ee5af"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1984/agentshield_0.2.1984_darwin_arm64.tar.gz"
      sha256 "130762a785dbaca24e70bf6b632c759d9ef165beb949382be2abedea3c1bc55d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1984/agentshield_0.2.1984_linux_amd64.tar.gz"
      sha256 "f43f4182543f1b32c031e370f1f547909250b4ad7e62837d4d8e6894f271eb18"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1984/agentshield_0.2.1984_linux_arm64.tar.gz"
      sha256 "171c60cbe4cd517b137623d4d48d89a0dbf93ec2eefe1e37d65c3bd203e212df"
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
