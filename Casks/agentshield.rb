cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2237"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2237/agentshield_0.2.2237_darwin_amd64.tar.gz"
      sha256 "df44090fa20ec60316a9ef50a1f5239d65451b965619529c9dcc0086674445b6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2237/agentshield_0.2.2237_darwin_arm64.tar.gz"
      sha256 "e8200ebcd539f2dbe29fbeb2faa078943df9b569757614e6c0344f72415f5147"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2237/agentshield_0.2.2237_linux_amd64.tar.gz"
      sha256 "28ed707334726bc4e68150b9324c95b6a6e64c7a48ab308e31118ad5f0ca26d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2237/agentshield_0.2.2237_linux_arm64.tar.gz"
      sha256 "7b00aa5656b0b6ce35834a3560b90657c05a88466d1b36199bfdd87dbfe6cb8a"
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
