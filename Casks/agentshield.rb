cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2156"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2156/agentshield_0.2.2156_darwin_amd64.tar.gz"
      sha256 "7e6150075596eb66fe24cbc3f9c03e5a746ac45b40b028992ec52ce9accbc166"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2156/agentshield_0.2.2156_darwin_arm64.tar.gz"
      sha256 "e465f0cd3d36a3bb7473893f8352a1200958fe105db8e5449f1bc1ba73e3656c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2156/agentshield_0.2.2156_linux_amd64.tar.gz"
      sha256 "dab3dbf0de29e3751ed60a346e0d92fae8508434565b44961637d6f90896a266"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2156/agentshield_0.2.2156_linux_arm64.tar.gz"
      sha256 "f8047ef640bd4ea406eae0c0b464f4efd454d5d9b66e1aadb06b67e2e1a65318"
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
