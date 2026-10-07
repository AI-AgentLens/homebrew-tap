cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2377"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2377/agentshield_0.2.2377_darwin_amd64.tar.gz"
      sha256 "5649c981415ca5f505bc75688fd6dcb903230f4fe5464495fc1fb3e8abe97542"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2377/agentshield_0.2.2377_darwin_arm64.tar.gz"
      sha256 "9fd1d6d4fd5ea68f4facd6dcd65b20c734b9f6215b3e37ec4f9cc818b4d57a62"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2377/agentshield_0.2.2377_linux_amd64.tar.gz"
      sha256 "7708a0cb2a44ff7838c098174373fdd1dc14797fd249e6813f765e4b21cbe9d5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2377/agentshield_0.2.2377_linux_arm64.tar.gz"
      sha256 "630f44b1a54153854d991971bfd71a10d3e43d2f2d827087472dbf6d546bc7ab"
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
