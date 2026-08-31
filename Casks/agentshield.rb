cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2002"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2002/agentshield_0.2.2002_darwin_amd64.tar.gz"
      sha256 "b33671721d6aca1830a5be0990f4eefb8a91828b6a9f81ccca5eed9899e9c468"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2002/agentshield_0.2.2002_darwin_arm64.tar.gz"
      sha256 "f7a6e089d5294acb8d5e86d93657d758f051d9ae785456a033ad791f01452145"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2002/agentshield_0.2.2002_linux_amd64.tar.gz"
      sha256 "2447818ae23c31c270d9eb80983d4ba8175be2b88f8995af3b2e89b6920d7bd3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2002/agentshield_0.2.2002_linux_arm64.tar.gz"
      sha256 "dc67831ce931bd779d6294dd2fefeac27d7cdb8511e70333a26c6f58e234b28c"
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
