cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.656"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.656/agentshield_0.2.656_darwin_amd64.tar.gz"
      sha256 "044d86d8af3cb436874f05e90f81edfbdc333586f1da2f723efaa63ee933ba74"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.656/agentshield_0.2.656_darwin_arm64.tar.gz"
      sha256 "0c25bda7633dcb5f96bc5b618148ded4d6a0100a20e41b632f2983010fbbe13f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.656/agentshield_0.2.656_linux_amd64.tar.gz"
      sha256 "d95fc10f06d1d8109ef9766c81d8c458ba2978756b5f29640755f2ced458e25a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.656/agentshield_0.2.656_linux_arm64.tar.gz"
      sha256 "f4db67bf65c3a42f27ae065e5246a204964e77038206f709fe2fc760b10838d3"
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
