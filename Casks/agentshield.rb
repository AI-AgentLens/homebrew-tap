cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1067"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1067/agentshield_0.2.1067_darwin_amd64.tar.gz"
      sha256 "774246a5673cfa2eae0b1991c746831e2316876334d0b07ef8929557327d3c7d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1067/agentshield_0.2.1067_darwin_arm64.tar.gz"
      sha256 "938f113844e6c82bdda7f02d4ee62936cf7f7892784840a600ca158a801c1edf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1067/agentshield_0.2.1067_linux_amd64.tar.gz"
      sha256 "ab98fe6929c5af344a9bd51b633a4b7f9fbabfc7b9b2bd981a6d122e3ecc72dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1067/agentshield_0.2.1067_linux_arm64.tar.gz"
      sha256 "610437760f05b16374e8c2fcfed4cef059db165098ed4bca8ec4e2ab830754d1"
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
