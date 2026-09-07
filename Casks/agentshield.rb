cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2074"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2074/agentshield_0.2.2074_darwin_amd64.tar.gz"
      sha256 "40db3021558654e91862502cdeb3553eb9f927a4d7dc834f73cc58334e052715"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2074/agentshield_0.2.2074_darwin_arm64.tar.gz"
      sha256 "39797eaefd2528a42e4978e6b3b0435624de3a4db2e15ae982f28af3ddc10262"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2074/agentshield_0.2.2074_linux_amd64.tar.gz"
      sha256 "68e45c34b9a35a609bc90b2042cf9935d67860eb72d12c027c29861f791d7e0a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2074/agentshield_0.2.2074_linux_arm64.tar.gz"
      sha256 "2675b0b5acccdd8ae49f3d6cae284a20ddb07dca660732f9f6987dcebbaf7b60"
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
