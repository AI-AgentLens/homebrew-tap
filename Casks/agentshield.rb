cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1623"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1623/agentshield_0.2.1623_darwin_amd64.tar.gz"
      sha256 "378366078f3a5b2634c9529c588025878a5080d97756499411800b0925632f7d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1623/agentshield_0.2.1623_darwin_arm64.tar.gz"
      sha256 "c719ed070ccec0f0d96db08085e23801b7b0cc71158926363a20b81c4666fd30"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1623/agentshield_0.2.1623_linux_amd64.tar.gz"
      sha256 "243e689e596709839fe372b272d0bedcc53ffa898a8489a7e7172f47e5aaa25d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1623/agentshield_0.2.1623_linux_arm64.tar.gz"
      sha256 "ea867b722c65eb079a676a84e38218976f69bf3162411972f712c914423e102b"
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
