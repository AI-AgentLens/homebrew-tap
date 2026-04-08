cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.505"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.505/agentshield_0.2.505_darwin_amd64.tar.gz"
      sha256 "6ef1cc94e02822a3deeb29548d048b5cada7dc260b1f15e2f49b0a0c4269af3e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.505/agentshield_0.2.505_darwin_arm64.tar.gz"
      sha256 "4209d6655140f7404c0eb469d83199a98c16b26da272fbcdc79eb04e76bc96ac"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.505/agentshield_0.2.505_linux_amd64.tar.gz"
      sha256 "f2027a17328a5fe9dfc021f00296147cbe95989d7c3a98052bdfd3a8f806c202"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.505/agentshield_0.2.505_linux_arm64.tar.gz"
      sha256 "12effd03582a513ba6c80b92361332ea65f6ad88e4cc5e896daf4f85539e8449"
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
