cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.186"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.186/agentshield_0.2.186_darwin_amd64.tar.gz"
      sha256 "5d4835767a6004b8162f772a8d580e7df003191d009c79206b52e68de2d0452a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.186/agentshield_0.2.186_darwin_arm64.tar.gz"
      sha256 "ccbd5025c7db3d83b201f14082681fa80591644f2f9018cdb994efd4f5c26695"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.186/agentshield_0.2.186_linux_amd64.tar.gz"
      sha256 "d538b9d23b18bd578358664655d762512a46cd69b8535996b5b52c5b7e656a47"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.186/agentshield_0.2.186_linux_arm64.tar.gz"
      sha256 "d45eecc2506f83502557596ec090ffb52053dbf9b2a9acfe147586178a011c3e"
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
